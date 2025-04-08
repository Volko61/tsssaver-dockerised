<?php
	/*
	* TSS Saver
	* Author: 1Conan
	* License: MIT
	*/
	$serverURL = "https://tssaver.volko.org/";  // Your domain
	$savedSHSHURL = $serverURL . "shsh/";       // Where SHSH blobs are saved
	
	$reCaptcha['enabled'] = false;              // Set to true if you want reCAPTCHA
	$reCaptcha['privateKey'] = "";              // Your reCAPTCHA private key
	$reCaptcha['publicKey'] = "";               // Your reCAPTCHA public key
	
	$db['server'] = "db";                       // Matches the MySQL service name in docker-compose.yml
	$db['name'] = "tsssaver";                   // Database name
	$db['user'] = "tssaver_user";               // Database username
	$db['password'] = "tssaver_password";       // Database password
	$db['table'] = "devices";                   // Table name
	
	$signedVersionsURL = "https://api.ipsw.me/v2.1/firmwares.json/condensed"; 
	
	$apnonce = array(
		'603be133ff0bdfa0f83f21e74191cf6770ea43bb', 
		'352dfad1713834f4f94c5ff3c3e5e99477347b95', 
		'42c88f5a7b75bc944c288a7215391dc9c73b6e9f', 
		'0dc448240696866b0cc1b2ac3eca4ce22af11cb3', 
		'9804d99e85bbafd4bb1135a1044773b4df9f1ba3'
	); // Add more apnonce values if needed
?>