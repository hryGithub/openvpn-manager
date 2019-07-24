<div class="row">
  <div class="col-md-4 col-md-offset-4">

    <form id="configuration_form" method="POST" class="panel panel-default">

      <div class="panel-heading">
        <h3 class="panel-title">获取配置文件</h3>
      </div>

      <div class="panel-body">
        <div class="form-group">
          <label for="configuration_username">用户名</label>
          <input type="text" id="configuration_username" name="configuration_username" class="form-control" autofocus/>
        </div>

        <div class="form-group">
          <label for="configuration_pass">密码</label>
          <input type="password" id="configuration_pass" name="configuration_pass" class="form-control" />
        </div>

        <div class="form-group">
          <label for="configuration_os">操作系统</label>
          <select name="configuration_os" id="configuration_os" class="form-control">
            <option value="gnu_linux">GNU/Linux</option>
            <option value="osx_viscosity">OSX/Viscosity</option>
            <option value="windows">Windows</option>
          </select>
        </div>

        <input id="configuration_get" name="configuration_get" type="submit" value="下载配置文件" class="btn btn-default" />
      </div>

    </form>

  </div>
</div>
