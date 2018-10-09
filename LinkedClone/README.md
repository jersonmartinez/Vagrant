## Documentation

### Creation of a virtual machine from linked cloning

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
        vb.name = "LinkedClone"
        vb.memory = "512"
        vb.cpus = "2"

        #This is the important line
        vb.linked_clone = true
    end
end
```
Assign the following instruction in the configuration of the virtual machine.
```ruby
vb.linked_clone = true
```

**Start the image**
```
vagrant up
```