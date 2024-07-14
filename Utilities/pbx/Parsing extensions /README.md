`all_used_numbers_YYxxx.py`
* Cкрипт для суммирования ВСЕХ ЗАНЯТЫХ номеров с БД разных fusionpbx 
* Отвечает на вопрос: "Какие номера заняты на fusionpbx old и fusionpbx new?"
* Файл на выходе: `all_used_numbers_{decade}xxx.csv`
---
`all_used_numbers_pairs.py`
* Скрипт для нахождения ИСПОЛЬЗУЕМЫХ парных номеров 
* Отвечает на вопрос: "Какие пары номеров заняты на fusionpbx old и fusionpbx new?"
* Файл на выходе: `all_USED_numbers_pairs_{decade1}xxx_{decade2}xxx.csv`
---
`free_pairs_numbers.py`
* Скрипт для поиска НЕ ИСПОЛЬЗУЕМЫХ парных номеров с БД разных fusionpbx
* Отвечает на вопрос: "Какие есть свободные пары номеров для использования?"
* Файл на выходе: `free_pairs_numbers_{decade1}xxx_{decade2}xxx.csv`
---
`free_solo_numbers_(NOT_pair).py`
* Скрипт для поиска ВОЗМОЖНЫХ номеров, которые еще не используются и не могут быть использованны как парные номера
* Отвечат на вопрос: "Какие есть свободные номера для использования (которые не могут быть использованны как парные номера)?"
* Файл на выходе: `free_solo_numbers_{decade}xxx.csv`