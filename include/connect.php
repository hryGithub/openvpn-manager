<?php
  require(dirname(__FILE__) . "/config.php");

	$options[PDO::ATTR_ERRMODE] = PDO::ERRMODE_EXCEPTION;
	$bdd = new PDO("sqlite:$db");
?>
