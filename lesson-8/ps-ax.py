from re import findall
from os import listdir


def get_pids():
    dirnames= []
    pids_list = []

    for name in listdir('/proc'):
        dirnames.append(name)


    for name in dirnames:
        pid = findall('[0-9]+', name)

        if len(pid) > 0:
            pids_list.append(pid[0])

    return pids_list

print(get_pids())

exit(0)
