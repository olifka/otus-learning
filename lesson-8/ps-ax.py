from os import listdir, system, popen
from datetime import datetime
from re import findall
from io import open


# Функция get_pids().
# Получает список номеров запущенных процессов (PIDs) путём анализа папки /proc -
# забираем имена каталогов, которые состоят только из чисел.
# Возвращает список PID'ов.
def get_pids():
    dirnames= []
    pids_list = []

    for name in listdir('/proc'):
        dirnames.append(name)

    for name in dirnames:
        pid = findall('[0-9]+', name)

        if len(pid) > 0:
            pids_list.append(int(pid[0]))

    return pids_list


# Функция get_cmd().
# Принимает на вход номер процесса (PID).
# Путём чтения из файла /proc/PID/cmdline получает значение команды-запуска заданного PID'а
# и возвращает её в виде строки.
def get_cmd(pid):
    path = "/proc/{}/cmdline".format(pid)
    f = open(path, 'r')
    cmd = f.read()
    f.close()

    return cmd


# Функция get_time(). Или выкрутасы_со_временем().
# Принимает на вход номер процесса (PID).
# Ихсодя из того, что папка-процесс создаётся в /proc одновременно с возникновением процесса
# за счёт даты создания этой папки получаем время жизни процесса:
# 'текущее значение времени' - 'время создания папки' ("ls -ld /proc/PID").
# Возвращает строку формата 'ЧЧ:ММ'.
def get_time(pid):
    now = datetime.now()
    current_year = now.year
    path = "/proc/{}".format(pid)
    # Т.к. popen возвращает данные совершенно неожиданным типом
    # пришлось сначала вызвать команду "ls -ld > /tmp/pid_file_info",
    # которая формирует временный файл в системе,
    bashCmd = "/bin/ls -ld {} > /tmp/pid_file_info".format(path)
    system(bashCmd)
    # а затем из "peopen(cat|awk)" получать нужную строку с датой в удобном формате.
    dt_start_str = popen("cat /tmp/pid_file_info|awk \'{ print $6\" \"$7\" \"$8 }\'").read()
    dt_start_str = "{} ".format(current_year) + dt_start_str.rstrip('\n')
    # Переводим строку в формат datetime.
    dt_start = datetime.strptime(dt_start_str.rstrip('\n'), "%Y %b %d %H:%M")
    delta = now - dt_start
    delta = (datetime.min + delta).time()

    return delta.strftime("%H:%M")


# Функция get_tty().
# Принимает на вход номер процесса (PID).
# Решение честно спёр со StackOverflow:
# если на файл "/proc/PID/fd/0" сделать "ls -l|awk '{ print $11 }'",
# то можно получить tty, используемый процессом.
# Возвращает название tty.
def get_tty(pid):
    path = "/proc/{}/fd/0".format(pid)
    bashCmd = "/bin/ls -l {}|awk \'{{ print $11 }}\'".format(path)
    tty = popen(bashCmd).read()

    return tty.rstrip('\n').lstrip('/dev/')


# Функция get_stat().
# Принимает на вход номер процесса (PID).
# Из файла "/proc/PID/status" grep'аем строку State,
# возвращаем её значение.
def get_stat(pid):
    path = "/proc/{}/status".format(pid)
    bashCmd = "cat {} |grep State|awk \'{{ print $2 }}\'".format(path)
    state = popen(bashCmd).read()

    return state.rstrip('\n')


# Список номеров процессов, запущенных в данный момент
pids_list = get_pids()

# Пародируем вывод нативного 'ps ax'
print("PID TTY STAT TIME COMMAND")

# Построчно выводим параметры запущенных процессов
for pid in pids_list:
    tty = get_tty(pid)
    state = get_stat(pid)
    work_time = get_time(pid)
    cmd = get_cmd(pid)
    print(pid, tty, state, work_time, cmd)


exit(0)
