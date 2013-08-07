module spine.util.funct;
//this is just the name of the current function(use with mixins)
enum string FUNCTION = `__FUNCTION__[__FUNCTION__.lastIndexOf(".")+1..$]`;