### Добавления вызова `index.py`
Лог файл git diff -- [файл](./diff.txt)  
В `runqueue.py` если билд выполнен без ошибок добавим вызов нового метода `write_indexfile`, который создает index файл в папке sstate-cache, локация которой берется из переменной окружения сборки.   
Создается в sstate-cache новый файл:
![Screenshot from 2024-09-12 15-09-15](https://github.com/user-attachments/assets/484e1f8f-6b79-4049-a26c-2596c97dbb03)

