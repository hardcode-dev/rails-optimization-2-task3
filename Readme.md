# Задание №3

В этом задании вам предлагается оптимизировать учебное `rails`-приложение.

Для запуска потребуется:
- `ruby 2.6.3`
- `postgres`

Запуск и использование:
- `bundle install`
- `bin/setup`
- `rails s`
- `open http://localhost:3000/автобусы/Самара/Москва`

## Описание учебного приложения
Зайдя на страницу `автобусы/Самара/Москва` вы увидите расписание автобусов по этому направлению.

## Что оптимизировать

### A. Импорт данных
При выполнении `bin/setup` в базу данных загружаются данные о рейсах из файла `fixtures/small.json`

Сама загрузка данных из файла делается очень наивно (и не эффективно).

В комплекте с заданием поставляются файлы
- `example.json`
- `small.json` (1K трипов)
- `medium.json` (10K трипов)
- `large.json` (100K трипов)

Нужно оптимизировать механизм перезагрузки расписания из файла так, чтобы он импортировал файл `large.json` **в пределах минуты**.

`rake reload_json[fixtures/large.json]`

Для импорта этого объёма данных
- вам может помочь гем https://github.com/zdennis/activerecord-import
- избегайте создания лишних транзакций
- профилируйте скрипт импорта изученными инструментами и оптимизируйте его!

### Б. Отображение расписаний
Сами страницы расписаний тоже формируются не эффективно и при росте объёмов начинают сильно тормозить.

Нужно найти и устранить проблемы, замедляющие формирование этих страниц.

Попробуйте воспользоваться
- [X] `rack-mini-profiler`
- [X] `rails panel`
- [X] `bullet`
- [ ] `explain` запросов

### Сдача задания
`PR` в этот репозиторий с кодом и case-study наподобие первых двух недель. На этот раз шаблона нет, законспектируйте ваш процесс оптимизации в свободной форме.

В case-study указать:
- за какое время выполняется импорт файла `fixtures/large.json`
- за какое время рендерится страница `автобусы/Самара/Москва`

Перед сдачей нужно убедиться, что результат работы страницы `автобусы/Самара/Москва` для данных из файла `fixtures/example.json` не изменился, то есть не было внесено никаких функциональных изменений, только оптимизации.

Лучше защититься от такой регрессии тестом.

### bonus
*Советую приступать к бонусу только после завершения основной части ДЗ.*

В качестве бонуса нужно справиться с импортом файлов `1M.json` (`codename mega`) и `10M.json` (`codename hardcore`)

- [mega](https://www.dropbox.com/s/mhc2pzgtt4bp485/1M.json.gz?dl=1)
- [hardcore](https://www.dropbox.com/s/h08yke5phz0qzbx/10M.json.gz?dl=1)

## Подсказки

### Мета-информация о данных

При реализации импорта нужно учесть наши инсайдерские знания о данных:
- первичным ключом для автобуса считаем `(model, number)`
- уникальных автобусов в файле `10M.json` ~ `10_000`
- ункикльных городов в файле `10M.json` ~ `100`
- сервисов ровно `10`, те что перечислены в `Service::SERVICES`

### Стриминг

Файл `10M.json` весит ~ `3Gb`.
Поэтому лучше не пытаться грузить его целиком в память и парсить.

Вместо этого лучше читать и парсить его потоково.

Это более-менее привычная схема, но знали ли вы, что в `Posgtres` тоже можно импортировать данные потоком?

Вот набросок потокового чтения из файла с потоковой записью в `Postgres`:

```ruby
@cities = {}

ActiveRecord::Base.transaction do
  trips_command =
    "copy trips (from_id, to_id, start_time, duration_minutes, price_cents, bus_id) from stdin with csv delimiter ';'"

  ActiveRecord::Base.connection.raw_connection.copy_data trips_command do
    File.open(file_name) do |ff|
      nesting = 0
      str = +""

      while !ff.eof?
        ch = ff.read(1) # читаем по одному символу
        case
        when ch == '{' # начинается объект, повышается вложенность
          nesting += 1
          str << ch
        when ch == '}' # заканчивается объект, понижается вложенность
          nesting -= 1
          str << ch
          if nesting == 0 # если закончился объкет уровня trip, парсим и импортируем его
            trip = Oj.load(str)
            import(trip)
            progress_bar.increment
            str = +""
          end
        when nesting >= 1
          str << ch
        end
      end
    end
  end
end

def import(trip)
  from_id = @cities[trip['from']]
  if !from_id
    from_id = cities.size + 1
    @cities[trip['from']] = from_id
  end

  # ...

  # стримим подготовленный чанк данных в postgres
  connection.put_copy_data("#{from_id};#{to_id};#{trip['start_time']};#{trip['duration_minutes']};#{trip['price_cents']};#{bus_id}\n")
end
```

### Plan

- чистим базу
- идём по огромному файлу
- по пути формируем в памяти вспомогательные справочники ограниченного размера (`cities`, `buses`, `buses_services`)
- сразу же стримим основные данные в базу (`trips`), чтобы не накапливать их
- после завершения файла сохраняем в базу сформированные справочники

### Notes

Можно использовать любые библиотеки для потоковой обработки `json` и вообще
