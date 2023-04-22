require 'ansible'

class Host < ApplicationRecord

    def collect_info
        # 定義目標主機
        group = Ansible::Inventory::Group.new(name: 'myhosts')
        host1 = Ansible::Inventory::Host.new(name: 'server1.test')
        group.add_host(host1)

        # 定義 Ansible 的運行選項
        options = Ansible::Runner::Options.new(
          inventory: Ansible::Inventory.new(groups: [group]),
          module_name: 'setup',
          module_args: '',
          subset: '',
          host_pattern: '',
          transport: 'ssh'
        )
        # 創建 Ansible Runner 對象
        runner = Ansible::Runner.new(options)
        # 執行 Ansible 命令
        result = runner.run
        # 解析收集到的主機信息
        info = result[:stdout_lines].map { |line| line.split(/ => /) }.to_h
        # 保存主機信息到數據庫
        self.update(
          os: info['ansible_distribution'] + ' ' + info['ansible_distribution_version'],
          cpu: info['ansible_processor'][/(\d+) .*$/, 1],
          memory: info['ansible_memtotal_mb'],
          disk: info['ansible_devices'].select { |k, v| k =~ /^sd/ }.values.map { |v| v['size'] }.join(', ')
        )
    end

end
