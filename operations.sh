# purge topic
bin/kafka-configs.sh --bootstrap-server localhost:9092 --alter --topic favourite-color-input --add-config retention.ms=1000

# describe topics with regular expression
bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic "favourite-color-\w+"

# create regular topic
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic favourite-color-input

#
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group favourite-color

# ➜  kafka_2.13-3.2.0 bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group favourite-color
#Consumer group 'favourite-color' has no active members.
#
#GROUP           TOPIC                                                                PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
#favourite-color favourite-color-input                                                0          12              12              0               -               -               -
#favourite-color favourite-color-KSTREAM-AGGREGATE-STATE-STORE-0000000004-repartition 0          5               5               0               -               -               -
#favourite-color favourite-color-KSTREAM-AGGREGATE-STATE-STORE-0000000003-repartition 0          1               1               0               -               -               -

# reset kstream application
  bin/kafka-streams-application-reset.sh --application-id favourite-color \
                                        --input-topics favourite-color-input \
                                        --intermediate-topics rekeyed-topic \
                                        --bootstrap-servers localhost:9092 \
                                        --force


bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic favourite-color-output --from-beginning \
--property print.key=true  --property print.value=true --group favourite-color-consumers

bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group favourite-color-consumers

bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092  --group favourite-color-consumers \
--topic favourite-color-output  --reset-offsets --to-earliest --execute

# start consumer
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic favourite-color-output --from-beginning \
--property print.key=true  --property print.value=true --group favourite-color-consumers

# see partition content
bin/kafka-run-class.sh kafka.tools.DumpLogSegments --deep-iteration --print-data-log \
--files /tmp/kafka-logs/favourite-color-output-0/00000000000000000000.log
