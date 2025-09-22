#!/usr/bin/env python3

import argparse


def surround_with_dash(input_string: str, final_length: int) -> str:
    if final_length > 0 and len(input_string) <= final_length:
        return input_string.center(final_length, "-")
    return input_string


def main() -> None:
    parser = argparse.ArgumentParser(description="Surround a string with dashes.")
    parser.add_argument("input_string", help="The string to surround")
    parser.add_argument("final_length", type=int, help="The final length of the string")
    args = parser.parse_args()

    result = surround_with_dash(args.input_string, args.final_length)
    print(result)


if __name__ == "__main__":
    main()
