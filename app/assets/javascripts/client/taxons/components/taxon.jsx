import { Component, PropTypes } from 'react';

export default class Taxon extends Component {
  handleClick(e) {
    e.preventDefault();
    this.props.onDeleteClick(this.props.code);
  }

  render() {
    return (
      <div className="taxon">
        <span className="label label-info">
          {this.props.name}
        </span>
        <a href='#' className="fa-icon pull-right"
        onClick={e => this.handleClick(e)}>
          <i className="fa fa-trash"></i>
        </a>
      </div>
    );
  }
}

Taxon.propTypes = {
  code: PropTypes.string,
  name: PropTypes.string
};
