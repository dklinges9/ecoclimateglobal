## 🌟 EcoClimateGlobal

A hugo powered static website for EcoClimateGlobal


### Maintainers

- [Dave Klinges](https://github.com/dklinges9)

## Navigation / Important Directories and Files

_Edit the Menu_: config/_default/menus.en.toml  
_Edit Site Pages_: most pages are stored in content/english  
_Documents_: content/english/docs/ Having a docs/ folder in the root no longer works for hyperlinking  
_Images_: assets/images/ (**NOT** the root images/ dir. That's a derived property)  
_Contact page_: configs/\_default/params.toml

<br>



### Contributing Your Changes

Push changes directly to:  
https://github.com/dklinges9/ecoclimateglobal/


A few minutes after pushing changes to remote, the website should be automatically re-deployed with the new updates (if your commit didn't break anything!)  

<br>
<br>


## Testing / Local Deployment

### Development Command

Start the development server using the following command:

```bash
npm run dev
```

Running this command should then generate a local address by which to view the development version of the website. This address will take the following form: [http://localhost:1313/](http://localhost:1313/)  

### Preview Command

Start the production server to preview your changes and test functionality:

```bash
npm run preview
```



### Build Command

Build the project for production, generating optimized static files:

```bash
npm run build
```


### Format Command

Format HTML and .md file:

```bash
npm run format
```

_Upon formating HTML per above command, You may receive a series of errors having to do with these modules:_  
node_modules/prettier  
node_modules/prettier-plugin-go-template

As of 10 November 2024, these errors do not seem to impact performance.



<br>
<br>



## Modifying CSS Templates

If you want to modify the CSS elements (e.g. change a default text size as part of the template for a given page, such as the _services_ template that renders your Research page), you will need to do so in the following directory:  

[themes/airspace-hugo/assets/scss/](themes/airspace-hugo/assets/scss/)  

Then, you will need to re-build the website before these changes will take place (see the [Build Command](#build-command) above)  

**DO SO WITH CAUTION.**  

Modifying the [css/style.css](css/style.css) file will make no changes, as this is a derived file.  



## _Setting up to Contribute_  

### Prerequisites

To contribute effectively, you'll need some prerequisites installed on your machine:

- **Hugo Extended v0.127+**: [[https://gohugo.io/installation/](https://gohugo.io/installation/)]
- **Node v18+**: [[https://nodejs.org/en/download/](https://nodejs.org/en/download/)]
- **Go v1.22+**: [[https://go.dev/doc/install](https://go.dev/doc/install)]

### Install Dependencies

Install all the necessary dependencies using the following command:

```bash
npm install
```
