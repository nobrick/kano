import { Component } from 'react';
import Taxon from './taxon';

export default class TaxonList extends Component {
  render() {
    return (
      <div className="taxonList">
        {this.props.taxons.map((taxon, index) =>
          <Taxon {...taxon}
          onDeleteClick={code => this.props.onDeleteClick(code)} />
        )}
      </div>
    );
  }
}
