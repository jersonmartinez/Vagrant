## Documentation

### Initial test on the creation of a virtual machine.

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
end
```
**Start the image**
```
vagrant up
```