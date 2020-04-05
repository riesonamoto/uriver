
var menuNum = 0;
var materialNums = [];

const formMain = document.getElementById('form_main');

function addMenuName() {
  var name = document.getElementById('new_menu_name').value;

  // 空文字列でなければ追加していく
  if (name != "") {
    text = '';
    text += '<div data-menuNum=' + String(menuNum) + ' id="menu_' + String(menuNum) + '" class="menu_item">'
    text += '<input type="text" name="menu_' + menuNum + '" value="' + name + '" hidden>';
    text += '<h1 class="menu_title">' + name + "の材料一覧</h1>";
    text += '<input type="text" name="' + menuNum + '_material_' + '0' + '" placeholder="材料名"' + 'required>';
    text += '<br>';
    text += '<button type="button" id="addMaterialNameBtn" onclick="addMaterialName(this)">入力欄を追加</button>';
    text += '</div>';
  
    formMain.insertAdjacentHTML('beforebegin', text);
  
    document.getElementById('new_menu_name').value = null;
    menuNum++;
    materialNums.push(1);
  };

};


function addMaterialName(mine) {
  const parentNum = mine.parentNode.getAttribute('data-menuNum')
  var materialNum = materialNums[parentNum];
  mine.insertAdjacentHTML('beforebegin', '<input type="text" name="' + parentNum + '_material_' + String(materialNum) + '" placeholder="材料名"><br>');
  materialNums[parentNum]++;
};