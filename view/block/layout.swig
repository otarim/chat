<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
	<title>{% block title%}{{appName}}-{% endblock %}</title>
	<link rel="stylesheet" href="/public/css/typo.css">
	<link rel="stylesheet" href="/public/css/animate.css">
</head>
<body>
	{% block content -%}
	{%- endblock %}
</body>
{% block script -%}
{%- endblock %}
</html>