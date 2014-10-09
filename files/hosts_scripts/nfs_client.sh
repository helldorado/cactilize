NFS=/proc/net/rpc/nfs
proc="getattr setattr lookup access readlink read write create mkdir symlink mknod remove rmdir rename link readdir readdirplus fsstat fsinfo pathconf commit"

i=4;

for a in $proc; do
#       echo -n "$a.value "
        grep proc3 $NFS \
                | cut -f $i -d ' ' \
                | awk '{print $1}'
        i=$(expr $i + 1)
done
