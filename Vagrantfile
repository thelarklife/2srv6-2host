# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  ###############
  # SRv6 VM 1~2 #
  ###############
  (2001..2002).each do |host_id|
    vm_name  = "SRv6-" + host_id.to_s
    config.vm.define vm_name do |srv6|
      srv6.vm.hostname = "SRv6-#{host_id}"
      srv6.vm.box = "bento/ubuntu-20.04"
      srv6.vm.network "forwarded_port", guest: 22, host: host_id.to_i, host_ip: "127.0.0.1"
      srv6.vm.synced_folder "./", "/root"
      srv6.vm.provider "virtualbox" do |vb|
        # Customize the amount of memory on the VM:
        vb.memory = "2048"
      end

      case host_id
      when 2001 then 
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db1::2",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2001"
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db2::1",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2002"
        srv6.vm.provision "shell", inline: <<-SHELL
          apt update
          apt install -y quagga
        SHELL
        srv6.vm.provision "shell", privileged: true, path: "./create_srv6.sh"
        srv6.vm.provision "shell", inline: <<-SHELL
          ip -6 route add 2001:db3::/64 encap seg6 mode encap segs 2001:db2::2 dev eth2
          ip -6 route add 2001:db2::1/128 encap seg6local action End.DX6 nh6 2001:db1::1 dev eth1
        SHELL

      when 2002 then
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db2::2",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2002"
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db3::1",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2003"
        srv6.vm.provision "shell", inline: <<-SHELL
          apt update
          apt install -y quagga
        SHELL
        srv6.vm.provision "shell", privileged: true, path: "./create_srv6.sh"
        srv6.vm.provision "shell", inline: <<-SHELL
          ip -6 route add 2001:db1::/64 encap seg6 mode encap segs 2001:db2::1 dev eth1
          ip -6 route add 2001:db2::2/128 encap seg6local action End.DX6 nh6 2001:db3::2 dev eth2
        SHELL
      end
    end
  end

  ###########
  # host VM #
  ###########
  (2231..2232).each do |host_id|
    vm_name  = "HostVM-" + host_id.to_s

    config.vm.define vm_name do |srv6|
      srv6.vm.hostname = "hostt-#{host_id}"
      srv6.vm.box = "bento/ubuntu-20.04"
      srv6.vm.network "forwarded_port", guest: 22, host: host_id.to_i, host_ip: "127.0.0.1"
      srv6.vm.synced_folder "./", "/root"

      case host_id
      when 2231 then
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db1::1",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2001"
        srv6.vm.provision "shell", inline: <<-SHELL
          apt update
          ip -6 route add 2001:db3::/64 via 2001:db1::2
        SHELL

      when 2232 then
        srv6.vm.network "private_network",
          auto_config: true,
          nic_type: "82540EM",
          ip: "2001:db3::2",
          netmask: "64",
          virtualbox__intnet: "srv6_seg2003"

        srv6.vm.provision "shell", inline: <<-SHELL
          apt update
          ip -6 route add 2001:db1::/64 via 2001:db3::1
        SHELL
      end

      srv6.vm.provider "virtualbox" do |vb|
        # Customize the amount of memory on the VM:
        vb.memory = "1024"
      end
    end
  end
end
