function find_in_panel(el, sel) {
  return $(el).closest('div#panel').find(sel);
}

function swap(el, this_sel, next_sel, fn) {
  $(el).closest(this_sel).fadeOut(100, function() {
    find_in_panel(el, next_sel).fadeIn(100, fn);
  });  
}

function inject_rule(el, id, fn) {
  var rule_el = find_in_panel(el, 'div#container-rule-prototypes').children('div#rule-' + id).clone(true);
  var rules_el = find_in_panel(el, 'div#container-account-rules');

  rule_el.hide();
  rules_el.append(rule_el);
  rule_el.fadeIn(100, fn);
};

function init() {
  on_page('accounts', function() {
    $('div#container-new-rule').each(function (i, el) {
      $(el).hide();
    });

    $('a[data-remote]').on('ajax:success', function (e, data, status, xhr) {
      var self = this;
      $(this).closest('div.row').fadeOut(100, function () {
        $(self).detach();
      });
    });

    $('button#add-rule').on('click', function () {
      swap(this, 'button#add-rule', 'div#container-new-rule');
    });

    $('button#button-cancel').on('click', function () {
      swap(this, 'div#container-new-rule', 'button#add-rule');
    });
    
    $('form#new_rule').on('ajax:success', function (e, data, status) {
      var self = this;
      
      inject_rule(self, data['id'], function() {
        swap(self, 'div#container-new-rule', 'button#add-rule');
      });
    });
  });
};

$(document).on('ready page:load', init);