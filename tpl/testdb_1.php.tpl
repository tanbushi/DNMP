<?php
$PDO = new PDO('mysql:host={{project_name}}_{{test_site_name}}_mariadb;dbname=mysql', 'root', '{{mysql_root_password_test}}');
var_dump($PDO);
$stmt=$PDO->prepare('select count(*) as userCount from user');
$stmt->execute();
echo '<br>';
echo 'rowCount='.$stmt->rowCount().'<br>';
while ($row=$stmt->fetch(PDO::FETCH_ASSOC)) {
      echo 'userCount='.$row['userCount'].'<br>';
}
?>
