node[:deploy].each do |application, deploy|
  if deploy[:custom_type] != 'django'
    next
  end
  
  # install requirements
  requirements = Helpers.django_setting(deploy, 'requirements', node)
  if requirements
    Chef::Log.info("Installing using requirements file: #{requirements} with sudo")
    pip_cmd = ::File.join(deploy["venv"], 'bin', 'pip')
    system "sudo -E #{pip_cmd} install --source=#{Dir.tmpdir} -r #{::File.join(deploy[:deploy_to], 'current', requirements)}" do
      cwd ::File.join(deploy[:deploy_to], 'current')
      user deploy[:user]
      group deploy[:group]
      environment 'HOME' => ::File.join(deploy[:deploy_to], 'shared')
    end
  else
    Chef::Log.debug("No requirements file found")
  end

  enable_gunicorn= Helpers.buildout_setting(deploy, 'enable_gunicorn', node)
  if enable_gunicorn
    supervisor_service application do
      action :start
    end
  end

end
