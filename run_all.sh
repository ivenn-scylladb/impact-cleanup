#!/bin/bash
#
# Run all scripts
#

# figure out values to be passed to raphael's script
#
smp_val=`/opt/scylladb/scripts/seastar-cpu-map.sh -n scylla | wc -l`
#gc_val=43200
gc_val=864000
#compact_val=7200
compact_val=2
output_file="twcs-output.txt"

echo "SMP value is $smp_val"

# Stop scylla service
# 

echo "Draining node"
nodetool drain
echo "stopping service"
sudo systemctl stop scylla-server
#
#
# Run Raphael's script along with the python script to create the file list and write to a local file
#
echo "Running description script and filtering to output file $output_file"
./twcs_sstable_description.py /var/lib/scylla/data/keyspace1/standard1-7f356bf0b6d911eea040ae62449b44b8 $smp_val $compact_val $gc_val |python3 find-files.py > $output_file
#./twcs_sstable_description.py /var/lib/scylla/data/irer/event_key-275314a0d35111eba679000000000001 $smp_val $compact_val $gc_val |python3 find-files.py > $output_file


# test dry run

for file in `cat $output_file`
do
	echo "Here I'd remove file $file"
done

sudo systemctl start scylla-server

exit 0

# run loop through output file and remove listed files
for file in `cat $output_file`
do
#	rm -f $file
done

# start scylla service
sudo systemctl start scylla-server


exit 0

