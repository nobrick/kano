class Taxon extends React.Component {
  render () {
    return (
      <div className="taxon">
        <span className="label label-info">
          {this.props.name}
        </span>
        <a href='#' className="fa-icon pull-right">
          <i className="fa fa-trash"></i>
        </a>
      </div>
    );
  }
}

Taxon.propTypes = {
  id: React.PropTypes.number,
  code: React.PropTypes.string,
  name: React.PropTypes.string,
  toDestroy: React.PropTypes.bool
};

module.exports = Taxon;
