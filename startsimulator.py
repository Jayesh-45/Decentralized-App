import sys
from simulator import run_simulator
if len(sys.argv) != 5:
    print('Invalid number of arguments passed')
    print('Usage: simulator.py <number of voters> <fraction_of_malicious> <fraction_of_very_hones> <simulations steps>')
    exit()
else:
    if not sys.argv[1].isdigit():
        print('Number of voters must be integers.')
        exit()
    if not sys.argv[2].replace('.','').isdigit() or float(sys.argv[2]) < 0 and float(sys.argv[2]) > 1:
        print(f'{sys.argv[2]} {isinstance(sys.argv[2], float)}')
        print("Invalid argument")
        print("Fraction should be between 0 and 1")
        exit()
    if not sys.argv[3].replace('.','').isdigit() or float(sys.argv[3]) < 0 and float(sys.argv[3]) > 1:
        print(f'{sys.argv[3]} {isinstance(sys.argv[3], float)}')
        print("Invalid argument")
        print("Fraction should be between 0 and 1")
        exit()
    if not sys.argv[4].isdigit():
        print('Number of steps must be integers.')
        exit()

run_simulator(int(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3]), int(sys.argv[4]))