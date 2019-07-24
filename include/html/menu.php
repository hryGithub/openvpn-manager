<div class="col-md-6 col-md-offset-3">
  <nav class="navbar navbar-default">

    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li <?php if(!isset($_GET['admin'])) echo 'class="active"'; ?>><a href="index.php">配置</a></li>
        <li <?php if(isset($_GET['admin'])) echo 'class="active"'; ?>><a href="index.php?admin">管理员</a></li>
      </ul>
    </div>

  </nav>
</div>
