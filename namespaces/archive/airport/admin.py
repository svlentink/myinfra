#!/usr/bin/env python3

import time
from kafka.admin import KafkaAdminClient, NewTopic

KAFKA_TOPIC='topic'

admin_client = KafkaAdminClient(
    bootstrap_servers="localhost:9092", 
    client_id='admin'
)

topic_list = []
topic_list.append(NewTopic(name=KAFKA_TOPIC, num_partitions=1, replication_factor=1))
admin_client.create_topics(new_topics=topic_list, validate_only=False)


time.sleep(999)

