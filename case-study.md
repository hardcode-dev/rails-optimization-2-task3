## Актуальная проблема
* Задача 1
    - Задача 1 Нужно оптимизировать механизм перезагрузки расписания из файла так, чтобы он импортировал файл `large.json` **в пределах минуты**.

## Feedback-Loop
* небольшой рефакторинг, добавление бенчмарка
* добавление pghero
* добавление теста на импорт данных


## Вникаем в детали системы, чтобы найти главные точки роста

* Задача 1
    - импорт medium.json PGHERO 46,629 раз запрос SELECT  "services".* FROM "services" WHERE "services"."name" = $1 LIMIT $2
