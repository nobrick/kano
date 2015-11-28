import { Component } from 'react';

export default class NewTaxon extends Component {
  handleClick(e) {
    e.preventDefault();
    const select = this.refs.select;
    const index = select.selectedIndex;
    if (index !== 0) {
      const code = select.options[index].value;
      this.props.onAddClick(code);
      select.selectedIndex = 0;
    }
  }

  render() {
    return (
      <div className="newTaxon">
        <select ref='select' >
          <option value=""></option>
          <optgroup label="电">
            <option value="electronic/lighting">灯具维修</option>
            <option value="electronic/socket">插座维修</option>
            <option value="electronic/appliance">电器维修</option>
            <option value="electronic/other">其它电路问题</option>
          </optgroup>
          <optgroup label="水">
            <option value="water/pipe">水管维修</option>
            <option value="water/faucet">龙头维修</option>
            <option value="water/toilet">厕所维修</option>
            <option value="water/other">其余管道问题</option>
          </optgroup>
          <optgroup label="其它">
            <option value="misc/shelf">相框和书架</option>
            <option value="misc/air_conditioning">空调清洁</option>
            <option value="misc/whitewash">粉刷及内部修缮</option>
            <option value="misc/lock">门锁问题</option>
            <option value="misc/other">其它定制服务</option>
          </optgroup>
        </select>
        <a className="pull-right" href="#" onClick={e => this.handleClick(e)}>
          <i className="fa fa-plus"></i>
        </a>
      </div>
    );
  }
}
