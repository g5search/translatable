/*
 * jQuery inlineEdit
 *
 * Copyright (c) 2009 Ca-Phun Ung <caphun at yelotofu dot com>
 * Licensed under the MIT (MIT-LICENSE.txt) license.
 *
 * http://github.com/caphun/jquery.inlineedit/
 *
 * Inline (in-place) editing.
 */
(function(a){var b=".inlineedit",c="inlineEdit-placeholder";a.fn.inlineEdit=function(c){var d=this;return this.each(function(){a.inlineEdit.getInstance(this,c).initValue()}).live(["click","mouseenter","mouseleave"].join(b+" "),function(b){var d=a.inlineEdit.getInstance(this,c),e=d.element.find(d.options.control),f=!!e.length;d.element.removeClass(d.options.hover);if(b.target!==e[0])switch(b.type){case"click":d[f?"mutate":"init"]();break;case"mouseover":case"mouseout":case"mouseenter":case"mouseleave":f||d.hoverClassChange(b)}})},a.inlineEdit=function(b,c){this.options=a.extend(!0,{},a.inlineEdit.defaults,c),this.element=a(b)},a.inlineEdit.getInstance=function(c,d){return a.inlineEdit.initialised(c)?a(c).data("widget"+b):new a.inlineEdit(c,d)},a.inlineEdit.initialised=function(c){var d=a(c).data("init"+b);return d!==undefined&&d!==null?!0:!1},a.inlineEdit.defaults={hover:"ui-state-hover",value:"",save:"",buttons:'<button class="save">save</button> <button class="cancel">cancel</button>',placeholder:"Click to edit",control:"input",cancelOnBlur:!1,saveOnBlur:!1},a.inlineEdit.prototype={init:function(){this.element.data("init"+b,!0),this.initValue(),this.mutate(),this.element.data("widget"+b,this)},initValue:function(){this.value(a.trim(this.element.text())||this.options.value),this.value()?this.options.value&&this.element.html(this.options.value):this.element.html(a(this.placeholderHtml()))},mutate:function(){var a=this;return a.element.html(a.mutatedHtml(a.value())).find("button.save").bind("click",function(b){return a.save(a.element,b),a.change(a.element,b),!1}).end().find("button.cancel").bind("click",function(b){return a.change(a.element,b),!1}).end().find(a.options.control).bind("blur",function(b){a.options.cancelOnBlur===!0?a.change(a.element,b):a.options.saveOnBlur==!0&&(a.save(a.element,b),a.change(a.element,b))}).bind("keyup",function(b){switch(b.keyCode){case 13:a.options.control!=="textarea"&&(a.save(a.element,b),a.change(a.element,b));break;case 27:a.change(a.element,b)}}).focus().end()},value:function(d){if(arguments.length){var e=d===this.options.placeholder?"":d;this.element.data("value"+b,a("."+c,this).length?"":e&&this.encodeHtml(e.replace(/\n/g,"<br />")))}return this.element.data("value"+b)},mutatedHtml:function(a){return this.controls[this.options.control].call(this,a)},placeholderHtml:function(){return'<span class="'+c+'">'+this.options.placeholder+"</span>"},buttonHtml:function(b){var c=a.extend({},{before:" ",buttons:this.options.buttons,after:""},b);return c.before+c.buttons+c.after},save:function(b,c){var d=this.element.find(this.options.control),e={value:this.encodeHtml(d.val())};d.val(e.value),((a.isFunction(this.options.save)&&this.options.save.call(this.element[0],c,e))!==!1||!this.options.save)&&this.value(e.value)},change:function(a,b){var c=this;this.timer&&window.clearTimeout(this.timer),this.timer=window.setTimeout(function(){c.element.html(c.value()||c.placeholderHtml()),c.element.removeClass(c.options.hover)},200)},controls:{textarea:function(a){return"<textarea>"+a.replace(/<br\s?\/?>/g,"\n")+"</textarea>"+this.buttonHtml({before:"<br />"})},input:function(a){return'<input type="text" value="'+a.replace(/(\u0022)+/g,"")+'">'+this.buttonHtml()}},hoverClassChange:function(b){a(b.target)[/mouseover|mouseenter/.test(b.type)?"addClass":"removeClass"](this.options.hover)},encodeHtml:function(b){var c=[{key:/</g,value:"&lt;"},{key:/>/g,value:"&gt;"},{key:/"/g,value:"&quot;"}],d=b;return a.each(c,function(a,b){d=d.replace(b.key,b.value)}),d}}})(jQuery)