# Тестовое задание

## Описание

bash скрипт для мониторинга процесса test в среде Linux. Запускается при старте ОС и каждую минуту при помощи systemd сервиса и таймера.

## Требования

* Ubuntu 24.04
* Git
* Python 3.12.3 (не обязательно)
* sudo (root) доступ к администрированию ОС

## Переменные скрипта

./test-monitor.sh

* `LOG_FILE` - полный путь до файла, куда пишется информация, если процесс был перезапущен или неудалось достучаться до API. По умолчанию - /var/log/test-monitoring/monitoring.log
* `STATE_FILE` - полный путь до файл, хранящего последний PID процесса. По умодчанию - $PWD/test-monitor.prevpid
* `API_URL` - HTTPS путь до API, куда отправляется POST запрос с пустым payloadом, в случае, если процесс запущен. По умолчанию - https://test.com/monitoring/test/api
* `PROCESS_NAME` - имя процесса, за которым небходимо наблюдать (мониторить). По умолчанию - test

## Установка

1. Клонировать репозиторий
```bash
git clone
```
2. Перейти в директорию, созданную в результате команды выше
```bash
cd test-monitor
```
3. Создать директорию для пользовательских сервиса и таймера
```bash
mkdir -p ~/.config/systemd/user
```
4. Скопировать файлы `test-monitor.service` и `test-monitor.timer` в `~/.config/systemd/user`
```bash
cp test-monitor.service test-monitor.timer ~/.config/systemd/user/
```
5. Создать директорию для файла monitoring.log
```bash
sudo mkdir -p /var/log/test-monitoring/
```
6. Задать пользователя root и основную группу пользователя как владельцев для новой директории
```bash
sudo chown root:$(id -gn) /var/log/test-monitoring
```
7. Задать права доступа 770 для новой директрии
```bash
sudo chmod 770 /var/log/test-monitoring
```
8. Перечитать пользовательские systemd юнит файлы сервиса и таймера
```bash
systemctl --user daemon-reload
```

Не обязательно

9. Перейти в директорию test-process
```bash
cd test-process
```
10. Создать venv для питоновского приложения фиктивного процесса test
```bash
python3 -m venv venv
```
11. Активировать виртуальное окружение
```bash
source venv/bin/activate
```
12. Установить в окружение небходимые библиотеки
```bash
pip install -r requirements.txt
```
13. Запустить на фоне программу, которая создаст фиктивный процесс test
```bash
python3 test_process.py &
```
14. Выйти из виртуального окружения
```bash
deactivate
```

## Запуск сервиса

```bash
systemctl --user enable --now test-monitor.timer
```

## Примеры работы с сервисом

* Проследить за обновлением информации из файла /var/log/test-monitoring/monitoring.log - 
```bash
tail -f /var/log/test-monitoring/monitoring.log
```
* Проследить логи сервиса test-monitor.service
```bash
journalctl --user -u test-monitor.service -f
```
* Остановить/запустить фиктивный процесс из под виртуального окружения (`source venv/bin/activate`)
```bash
pkill -x test
```
```bash
python3 test-process.py &
```
* Остановить и выключить сервис и таймер
```bash
systemctl --user stop test-monitor.timer && systemctl --user disable test-monitor.timer
```
* Просмотреть информацию о таймере
```bash
systemctl --user list-timers | grep test-monitor
```