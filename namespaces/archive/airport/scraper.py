#!/usr/bin/env python3

import requests
import time
from kafka import KafkaProducer

KAFKA_TOPIC='topic'


def get_file(url: str ="https://raw.githubusercontent.com/jpatokal/openflights/master/data/routes.dat"):
    r = requests.get(url)
    return r.text


if __name__ == "__main__":
    producer = KafkaProducer(bootstrap_servers='localhost:9092')

    lines = get_file().split("\r\n")
    print(f"File contains {len(lines)} lines")

    for line in lines:
        producer.send(KAFKA_TOPIC, line.encode())
        producer.flush()

        print(f"Published: {line}")
        time.sleep(1)

