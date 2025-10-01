#!/usr/bin/env python3

import time


def progress_bar(iterations: int) -> None:
    bar_length = 50

    print("Starting task.")

    for i in range(iterations + 1):
        percent = i / iterations
        filled_length = int(bar_length * percent)
        bar = "█" * filled_length + "-" * (bar_length - filled_length)

        progress_str = f"\rTask progress: |{bar}| {percent:.1%} complete"

        print(progress_str, end="", flush=True)
        time.sleep(0.05)

    print()
    print("Task complete!")


def main() -> None:
    progress_bar(100)


if __name__ == "__main__":
    main()
