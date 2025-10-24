// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Product {
    string nameProduct;
    uint price;
    uint quantity;
    string sellerName;
}

struct Order {
    string nameProduct;
    uint price;
    uint quantity;
}

contract StoresManager {
    mapping(string => Product) private products;
    string[] private productNames;
    mapping(string => string[]) private sellerProductNames;
    mapping(string => Order[]) private userPurchases;

    // ======================
    // Internal Utilities
    // ======================
    function compareStrings(
        string memory _a,
        string memory _b
    ) private pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    // ======================
    // Product Management
    // ======================
    function addProduct(
        string memory _sellerName,
        string memory _nameProduct,
        uint _price,
        uint _quantity
    ) public {
        // --- Kiểm tra nhập liệu ---
        require(bytes(_sellerName).length > 0, "Ten nguoi ban khong duoc de trong");
        require(bytes(_nameProduct).length > 0, "Ten san pham khong duoc de trong");
        require(_price > 0, "Gia san pham phai lon hon 0");
        require(_quantity > 0, "So luong phai lon hon 0");
        require(!compareStrings(_sellerName, _nameProduct), "Ten nguoi ban va san pham khong duoc giong nhau");

        // --- Kiểm tra trùng sản phẩm ---
        Product storage prod = products[_nameProduct];
        require(bytes(prod.nameProduct).length == 0, "San pham da ton tai");

        // --- Thêm sản phẩm ---
        products[_nameProduct] = Product(_nameProduct, _price, _quantity, _sellerName);
        productNames.push(_nameProduct);
        sellerProductNames[_sellerName].push(_nameProduct);
    }

    function updatePrice(
        string memory _sellerName,
        string memory _nameProduct,
        uint _newPrice
    ) public {
        require(_newPrice > 0, "Gia moi phai lon hon 0");

        Product storage prod = products[_nameProduct];
        require(bytes(prod.nameProduct).length != 0, "Khong tim thay san pham");
        require(compareStrings(prod.sellerName, _sellerName), "Khong co quyen thay doi gia");

        prod.price = _newPrice;
    }

    function getProductsBySeller(
        string memory _sellerName
    ) public view returns (Product[] memory) {
        require(bytes(_sellerName).length > 0, "Ten nguoi ban khong hop le");

        string[] memory names = sellerProductNames[_sellerName];
        Product[] memory sellerProducts = new Product[](names.length);

        for (uint i = 0; i < names.length; i++) {
            sellerProducts[i] = products[names[i]];
        }
        return sellerProducts;
    }

    function getProductInfo(
        string memory _nameProduct
    )
        public
        view
        returns (uint price, uint quantity, string memory sellerName)
    {
        require(bytes(_nameProduct).length > 0, "Ten san pham khong hop le");
        Product storage prod = products[_nameProduct];
        require(bytes(prod.nameProduct).length != 0, "Khong tim thay san pham");
        return (prod.price, prod.quantity, prod.sellerName);
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productNames.length);
        for (uint i = 0; i < productNames.length; i++) {
            allProducts[i] = products[productNames[i]];
        }
        return allProducts;
    }

    // ======================
    // Buying
    // ======================
    function buyProduct(
        string memory _username,
        string memory _nameProduct,
        uint _quantity
    ) public {
        // --- Kiểm tra dữ liệu nhập ---
        require(bytes(_username).length > 0, "Ten nguoi mua khong duoc de trong");
        require(bytes(_nameProduct).length > 0, "Ten san pham khong hop le");
        require(_quantity > 0, "So luong mua phai lon hon 0");

        Product storage prod = products[_nameProduct];
        require(bytes(prod.nameProduct).length != 0, "Khong tim thay san pham");
        require(prod.quantity >= _quantity, "Khong du hang trong kho");

        // --- Cập nhật dữ liệu ---
        prod.quantity -= _quantity;
        userPurchases[_username].push(Order(_nameProduct, prod.price, _quantity));
    }

    function getPurchaseHistory(
        string memory _username
    ) public view returns (Order[] memory) {
        require(bytes(_username).length > 0, "Ten nguoi mua khong hop le");
        return userPurchases[_username];
    }
}
