## Documentation

### Configure new storage disks
Add 2 additional disks. The first with 300GB of space, and the second with 100GB of space.

Initialize the virtual machine with the box: `debian/jessie64` to `VirtualBox`.

- - -

**Initialize**
```
vagrant init -m debian/jessie64
```
**Vagrantfile**

```ruby

Vagrant.configure("2") do |config|
    config.vm.box = "debian/jessie64"
    config.vm.hostname = "jerson-martinez"

    config.vm.provider "virtualbox" do | vb |
        vb.name = "ConfigDisk"
        vb.memory = "512"
        vb.cpus = "2"

        vb.linked_clone = true

        #Code Importants
        firt_disk   = 'tmp/disk.vdi'
        second_disk = 'tmp/disktwo.vdi'
        controller  = "SATA Controller"
        device      = 0
        type        = "hdd"

        unless File.exist?(firt_disk)
            vb.customize ['createhd', 
                        '--filename',   firt_disk, 
                        '--size',       300 * 1024]
        end
        
        unless File.exist?(second_disk)
            vb.customize ['createhd', 
                        '--filename',   second_disk, 
                        '--size',       100 * 1024]
        end

        vb.customize ['storageattach', :id, 
                   '--storagectl',      "#{controller}", 
                   '--port',            1, 
                   '--device',          "#{device}", 
                   '--type',            "#{type}", 
                   '--medium',          firt_disk]

        vb.customize ['storageattach', :id, 
                   '--storagectl',      "#{controller}", 
                   '--port',            2, 
                   '--device',          "#{device}", 
                   '--type',            "#{type}", 
                   '--medium',          second_disk]

    end
end
```

**The disk controller is found as follows**
```
VBoxManage showvminfo [uid|name] | grep "SATA"
```

**Adding disk**
```ruby
firt_disk   = 'tmp/disk.vdi'
controller  = "SATA Controller"
device      = 0
type        = "hdd"

unless File.exist?(firt_disk)
    vb.customize ['createhd', 
            '--filename',   firt_disk, 
            '--size',       300 * 1024]
end

vb.customize ['storageattach', :id, 
            '--storagectl',      "#{controller}", 
            '--port',            1, 
            '--device',          "#{device}", 
            '--type',            "#{type}", 
            '--medium',          firt_disk]

```

**Start the image**
```
vagrant up
```

**Access by SSH**
```
vagrant ssh
```

**Check the disks**
```
lsblk
sudo fdisk -l
```