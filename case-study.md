# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникли следующие проблемы:
* Долгий импорт данных в БД
* Долгий рендеринг страницы расписаний

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику:
* Бюджет загрузки файла c 1K трипов (fixtures/small.json) - 7.5 сек. (23 сек.)
* Бюджет загрузки файла со 100К трипов (fixtures/large.json) - 60 сек. (to match...)

## Гарантия корректности работы оптимизированной программы
Тест корректности загрузки данных `spec/json_loader_spec.rb`. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`

Вот как я построил `feedback_loop`:
- анализ отчетов
- изменения в программе
- замер метрики
- запуск теста

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался:
- rack-mini-profiler
- bullet

Вот какие проблемы удалось найти и решить:

### Итерация №1
- Загрузка данных с помощью activerecord-import gem
    * Loading data from fixtures/small.json - 23.2 сек -> 7.5 сек
    * Loading data from fixtures/large.json - 58.31 сек (в рамках бюджета).

### Итерация №2
- Рендеринг страницы - 730ms (Views: 607.3ms | ActiveRecord: 86.6ms)
- Bullet Warnings
  * USE eager loading detected Trip => [:bus] Add to your query: .includes([:bus])
- Добавил preload(bus: :services). Заменил has_and_belongs_to_many на has_many through.
  - Рендеринг страницы - 518ms (Views: 447.1ms | ActiveRecord: 44.4ms)
  - Rendering: trips/index.html.erb 19 sql --> 12 sql
  - Bullet Warnings отсутствуют.

### Итерация №3
- rack-mini-profiler показал аж 12 (!) паршалов services.html.erb Rendering trips/_services.html.erb, с помощью рендеринга коллекций, удалось убрать этот лишний паршал.
- Убрал один лишний запрос заменой @trips.count на @trips.load.size
- Рендеринг страницы - 495ms (Views: 424.9ms | ActiveRecord: 43.0ms)

### Итерация №4
- PgHero предложил создать индексы:
```
CREATE INDEX CONCURRENTLY ON trips (from_id, to_id)
CREATE INDEX CONCURRENTLY ON buses_services (bus_id)
CREATE INDEX CONCURRENTLY ON buses (number)
```
- Рендеринг страницы не изменился (?)- 514ms (Views: 438.1ms | ActiveRecord: 46.6ms)
- find_by_name! --> find_by!