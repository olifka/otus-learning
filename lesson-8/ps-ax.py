from re import findall
from os import listdir, system, popen
from io import open
from datetime import datetime


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

pids_list = get_pids()

def get_cmd(pid):
    path = "/proc/{}/cmdline".format(pid)
    f = open(path, 'r')
    cmd = f.read()
    f.close()

    return cmd


def get_time(pid):
    now = datetime.now()
    current_year = now.year
    path = "/proc/{}".format(pid)
    bashCmd = "/bin/ls -ld {} > /tmp/pid_file_info".format(path)
    system(bashCmd)
    dt_start_str = popen("cat /tmp/pid_file_info|awk \'{ print $6\" \"$7\" \"$8 }\'").read()
    dt_start_str = "{} ".format(current_year) + dt_start_str.rstrip('\n')
    dt_start = datetime.strptime(dt_start_str.rstrip('\n'), "%Y %b %d %H:%M")

    delta = now - dt_start
    delta = (datetime.min + delta).time()

    return delta.strftime("%H:%M")


def get_tty(pid):
    path = "/proc/{}/fd/0".format(pid)
    bashCmd = "/bin/ls -l {}|awk \'{{ print $11 }}\'".format(path)
    tty = popen(bashCmd).read()
    return tty.rstrip('\n').lstrip('/dev/')


# def get_stat(pid):
    # something

print("PID TTY TIME COMMAND")

for pid in pids_list:
    tty = get_tty(pid)
#     get_stat(pid)
    work_time = get_time(pid)
    cmd = get_cmd(pid)
    print(pid, tty, work_time, cmd)


exit(0)
