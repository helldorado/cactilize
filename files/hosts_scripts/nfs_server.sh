NFSD=/proc/net/rpc/nfsd
proc="getattr setattr lookup access readlink read write create mkdir symlink mknod remove rmdir rename link readdir readdirplus fsstat fsinfo pathconf commit"

i=4;

for a in $proc; do
        grep proc3 $NFSD \
                | cut -f $i -d ' ' \
                | awk '{print $1}'
        i=$(expr $i + 1)
done
