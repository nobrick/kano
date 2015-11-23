NewTaxon = require('./new_taxon');
TaxonList = require('./taxon_list');

class TaxonBox extends React.Component {
  render () {
    return (
      <div className="taxonBox">
        <TaxonList />
        <NewTaxon />
      </div>
    );
  }
}
module.exports = TaxonBox;
