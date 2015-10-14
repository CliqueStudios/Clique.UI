<?php
	$dir = dirname(dirname(__DIR__)) . '/php/functions/functions.php';
	require_once $dir;
?><!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>Mocha Tests</title>
		<link rel="stylesheet" href="../../node_modules/mocha/mocha.css" />
	</head>
	<body>
		<div id="mocha">
			<ul id="mocha-report">
				<li class="suite">
					<h1><a href="<?php echo get_url(get_page()); ?>">Clique.UI Unit Tests</a></h1>
					<hr>
					<ul>
						<?php

							function get_pagename($path) {
								$filename = basename($path);
								$array = explode('.', $filename);
								array_pop($array);
								$filename = implode('.', $array);
								return ucwords($filename);
							}

							$directory = __DIR__;
							$local_url = 'http://' . LOCALURL;
							$files = get_files_list($directory);
							foreach($files as $i => $file) {
								if($file->extension !== 'html') {
									continue;
								}
								$name = get_pagename($file->name);
								$path = str_replace(get_root_directory(), '', $file->name);
								$url = get_url($path);
								?>
								<li class="suite">
									<h1><a href="<?php echo $url; ?>">#<?php echo $name; ?></a></h1>
								</li>
								<?php
							}
						?>
					</ul>
				</li>
			</ul>
		</div>
		<script src="../../docs/js/jquery.js"></script>
	</body>
</html>
