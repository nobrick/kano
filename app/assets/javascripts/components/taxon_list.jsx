Taxon = require('./taxon');
class TaxonList extends React.Component {
  render () {
    return (
      <div className="taxonList">
        <Taxon code="electronic/lighting" name="灯具维修" toDestroy={false} />
        <Taxon code="electronic/socket" name="插座维修" toDestroy={false} />
        <Taxon code="electronic/socket" name="插座维修" toDestroy={false} />
        <Taxon code="misc/whitewash" name="粉刷及内部修缮" toDestroy={false} />
        <Taxon code="electronic/socket" name="插座维修" toDestroy={false} />
      </div>
    );
  }
}
module.exports = TaxonList;
