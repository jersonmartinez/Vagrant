## Documentation

### Forwarded Port
Expose the port 80 of the virtual machine to the physical machine by means of the 8080.

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

    #This is the important line
    config.vm.network "forwarded_port", guest: 80, host: 8080

    config.vm.provider "virtualbox" do | vb |
        vb.name = "ForwardedPort"
        vb.memory = "512"
        vb.cpus = "2"
        vb.linked_clone = true
    end
end
```

**Start the image**
```
vagrant up
```