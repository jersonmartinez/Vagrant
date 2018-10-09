## Documentation

### Choosing the provider VirtualBox and adding resources as: memory, cpus, name and hostname for the virtual machine

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

    #These are the important lines
    config.vm.hostname = "jerson-martinez"

    config.vm.provider "virtualbox" do | vb |
        vb.name = "ConfigProviders"
        vb.memory = "512"
        vb.cpus = "2"
    end
end
```

**Start the image**
```
vagrant up
```