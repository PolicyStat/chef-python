#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: python
# Recipe:: pip
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

python_bindir  = "#{node['python']['prefix_dir']}/bin"
pip_bindir     = "#{node['python']['pip']['prefix_dir']}/bin"
pip_version     = node['python']['pip']['version']

# Ubuntu's python-setuptools, python-pip and python-virtualenv packages
# are broken...this feels like Rubygems!
# http://stackoverflow.com/questions/4324558/whats-the-proper-way-to-install-pip-virtualenv-and-distribute-for-python
# https://bitbucket.org/ianb/pip/issue/104/pip-uninstall-on-ubuntu-linux
remote_file "#{Chef::Config[:file_cache_path]}/distribute_setup.py" do
  source "https://s3.amazonaws.com/pstat-test-media/distribute_setup.py"
  mode "0644"
  not_if { ::File.exists?("#{pip_bindir}/pip") }
end

bash "install-pip" do
  v = "==#{pip_version}" unless pip_version.eql?('latest')
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  #{python_bindir}/python distribute_setup.py
  easy_install pip#{v}
  EOF
  not_if { ::File.exists?("#{pip_bindir}/pip") }
end

packages = node[:python][:packages]
packages = packages.split() if packages.is_a? String

packages.each do |pkg|
  pkg = "#{pkg} latest".split()
  name = pkg[0]
  version = pkg[1]
  python_pip name do
    # upgrade will install if the package does not exist
    action :upgrade
    version version
  end
end
