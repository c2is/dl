<?php

$key = substr($_SERVER['REQUEST_URI'], 1, strlen($_SERVER['REQUEST_URI']));

if (! preg_match("/^[a-z]{4}$/", $key, $matches)) {
	die("Incorrect url");
}

$mapping = file_get_contents("./mapping.txt");
$mapping = explode("\n", $mapping);

foreach ($mapping as $rule) {
	if (strpos($rule, $key." ") !== false)  {

		$filename = explode(" ", $rule)[1];
		response($filename);
		
		break;
	}
}

function response($filename) {
		if (! file_exists($filename)) {
			die("File ".$filename." doesn't exist");
		} elseif (is_dir($filename)) {
			if (! file_exists($filename.".zip")) {
				$compression = shell_exec("zip -r ".$filename.".zip ".$filename);
			}
			if (file_exists($filename.".zip")) {
				$filename = $filename.".zip";

			} else {
				die("Zip compression error");

			}
		}
		header('Content-Description: File Transfer');
		header('Content-Type: application/octet-stream');
		header('Content-Disposition: attachment; filename='.$filename);
		header('Content-Length: ' . filesize($filename));
		header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
		header('Pragma: public');
		header('Expires: 0');

		$handle = fopen($filename, "rb");
		while (!feof($handle)){
			
			echo fread($handle, 8192);
		}
		fclose($handle);


}