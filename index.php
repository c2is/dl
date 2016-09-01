<?php

$key = substr($_SERVER['REQUEST_URI'], 1, strlen($_SERVER['REQUEST_URI']));

if (! preg_match("/^[a-z]{4}$/", $key, $matches)) {
	die("Incorrect url");
}

$mapping = file_get_contents("./mapping.txt");
$mapping = explode("\n", $mapping);

foreach ($mapping as $rule) {
	if (strpos($rule, $key." ") !== false)  {
		$start = strlen($key." ");
		$filename = substr($rule, $start, strlen($rule));
		response($filename);
		
		break;
	}
}

function response($filename) {
		chdir("files");
		if (! file_exists($filename)) {
			die("File ".$filename." doesn't exist");
		} elseif (is_dir($filename)) {
			if (! file_exists("../zipped/".$filename.".zip")) {
				$compression = shell_exec('zip -r "../zipped/'.$filename.'.zip" "'.$filename.'"');
			}
			if (file_exists("../zipped/".$filename.".zip")) {
				$filename = "../zipped/".$filename.".zip";

			} else {
				die("Zip compression error");

			}
		}
		header('Content-Description: File Transfer');
		header('Content-Type: application/octet-stream');
		header('Content-Disposition: attachment; filename='.basename($filename));
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