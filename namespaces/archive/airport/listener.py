#!/usr/bin/env python3

import datetime
from kafka import KafkaConsumer, TopicPartition

KAFKA_TOPIC='topic'
OUTPUT_DIR='/shared'


if __name__ == "__main__":
    consumer = KafkaConsumer(bootstrap_servers='localhost:9092')

    consumer.subscribe([KAFKA_TOPIC])

    for msg in consumer:
        print(msg)

        filepath = f"{OUTPUT_DIR}/{datetime.datetime.utcnow().isoformat()}.txt"
        with open(filepath,"w") as fp:
            fp.write(str(msg.value.decode()))

