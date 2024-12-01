import sys
from dotenv import dotenv_values
import requests
from requests.exceptions import HTTPError

day = sys.argv[1]
url = f"https://adventofcode.com/2024/day/{day}/input"

try:
    print (url)
    response = requests.get(url, headers = {
        'Cookie': f"session={dotenv_values('.env')['ADVENT_SESSION']}",
        'DNT': "1"
    })

    response.raise_for_status()
except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')
else:
    with open(f"aoc_elixir/input/{day}.txt", 'w') as f:
        f.write(response.text)
