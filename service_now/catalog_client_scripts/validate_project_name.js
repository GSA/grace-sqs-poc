function onChange(control, oldValue, newValue, isLoading) {
   if (isLoading || newValue == '') {
      return;
   }

   //Validates project_name against a regex
	var err_field = 'project_name';
	var err_message = 'Project Name is invalid.', regex = /[A-Za-z0-9-]{3,16}/;
	var err_flag = 'false';
	err_flag = regex.test(g_form.getValue(err_field));
	if (!err_flag){
		g_form.clearValue(err_field);
		alert(err_message);
	}
}
