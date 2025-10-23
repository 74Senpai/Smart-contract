// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStoreContract {
    // Thêm sản phẩm: Cần tên người bán
    function addProduct(string memory _sellerName, string memory _nameProduct, uint _price, uint _quantity) external;

    // Lấy thông tin sản phẩm: Chỉ cần tên sản phẩm
    function getProductInfo(string memory _nameProduct) external view returns (uint price, uint quantity, string memory sellerName);

}


struct Order {
    string nameProduct;
    uint price;
    uint quantity;
}


contract ProductManager {
    
    IStoreContract public storeContract;

    // Địa chỉ store
    constructor(address _storeAddress) {
        storeContract = IStoreContract(_storeAddress);
    }

    // Thêm sản phẩm vào store
    function addProduct(string memory _sellerName, string memory _nameProduct, uint _price, uint _quantity) public {
        storeContract.addProduct(_sellerName, _nameProduct, _price, _quantity);
    }

    // Lấy thông tin sản phẩm
    function getProductInfo(string memory _nameProduct) public view returns (uint price, uint quantity, string memory sellerName) {
        return storeContract.getProductInfo(_nameProduct);
    }
}