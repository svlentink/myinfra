#!/usr/bin/env python3


import csv
import io
import json
from kafka import KafkaConsumer, TopicPartition

KAFKA_TOPIC='topic'
OUTPUT_DIR='/shared'


if __name__ == "__main__":
    consumer = KafkaConsumer(bootstrap_servers='localhost:9092')

    consumer.subscribe([KAFKA_TOPIC])

    for msg in consumer:
        print(msg)

        fileheader = "airline,sourceAirport,sourceAirportId,destinationAirport,destinationAirportId,codeshare,stops,equipment"
        headerlength = len(fileheader.split(','))

        csv_data = f"{fileheader}\n{msg.value.decode()}"
        fp = io.StringIO(csv_data)
        reader = csv.DictReader(fp, delimiter=",")

        for row in reader:
            print(row)
            if (len(row.keys())):
                jsonstr = json.dumps(row)
                with open('/shared/test.json', 'w') as fp:
                    fp.write(jsonstr)
            else:
                print("error not enough fields in line, the backslash n line")

