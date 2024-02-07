fishcmd="/home/ivenn/bin/fcsh-training.sh"
cluster="vladz-test-custom-build-install"
localfilepath="/home/ivenn/Working/git/field-engineering/ad-hoc-scripts/"
localfile="twcs_sstable_description.py"
localfilepath2="/home/ivenn/vault/impact-project1"
localfile2="find-files.py"
localfile3="run_all.sh"

bucket_log=`$fishcmd --command-parts-delimiter "/" --run "gcp/$cluster/files_bucket"`

echo $bucket_log

scp $localfilepath/$localfile $bucket_log
scp $localfilepath2/$localfile2 $bucket_log
scp $localfilepath2/$localfile3 $bucket_log

for h in `$fishcmd --command-parts-delimiter ":" --run "gcp:$cluster:list" | grep ^"scylla:" | cut -d":" -f2-`
do
	echo $h
	$fishcmd --command-parts-delimiter "/" --run "gcp/$cluster/scp $localfile $h:."
	$fishcmd --command-parts-delimiter "/" --run "gcp/$cluster/scp $localfile2 $h:."
	$fishcmd --command-parts-delimiter "/" --run "gcp/$cluster/scp $localfile3 $h:."
done
