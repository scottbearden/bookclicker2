class InsertProxies < ActiveRecord::Migration[5.0]
  def change
    ['some old list of proxies...'].each do |ip|
      Proxy.create!(ip: ip)
    end
  end
end
