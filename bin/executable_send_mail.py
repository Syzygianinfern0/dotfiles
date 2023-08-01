#!python
import argparse

import requests


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--subject")
    parser.add_argument("--body")
    parser.add_argument("--comment")
    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    headers = {
        "Content-Type": "application/json",
    }

    json_data = {
        "value1": f"{args.subject}",
        "value2": f"{args.body}",
        "value3": f"{args.comment}",
    }

    response = requests.post(
        "https://maker.ifttt.com/trigger/SCRIPT_END_TRIGGER/with/key/CN07CQ_6PmT_0UjxV9YvMRmpyvCpIaooppQP3-bmIc",
        headers=headers,
        json=json_data,
    )


if __name__ == "__main__":
    main()


# import sys

# import requests

# script_name = sys.argv[1]
# exit_code = sys.argv[2]
# output = sys.argv[3]

# # exit_codes_lut = {
# #     "0": "COMPLETED 🎉",
# #     "1": "IMPERMISSIBLE 🧐",
# #     "2": "IMPERMISSIBLE 🙅",
# #     "26": "IMPERMISSIBLE 🙅",
# #     ""
# # }
# json_data = {
#     "value1": f"{script_name}",
#     "value2": f"COMPLETED - {exit_code}",
#     "value3": output,
# }

# response = requests.post(
#     "https://maker.ifttt.com/trigger/SCRIPT_END_TRIGGER/with/key/CN07CQ_6PmT_0UjxV9YvMRmpyvCpIaooppQP3-bmIc",
#     json=json_data,
# )
